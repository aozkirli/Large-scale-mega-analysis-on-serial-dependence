function [model,sdp] = SD_ma_model_bayesian(Se,Sd,Pt,tau,theta,nback,meas)
trials      = numel(theta);
%% function handles
% convert standard deviation in degrees to concentration 'k' 
dSd2k       = @(x) sd2k(deg2rad(x)*2);
% normalize to sum 1
sumnorm     = @(x) x./sum(x);
% orientation channels
ch          = 0:179; % to update for MOTION
% orientation channels response function (symmetric VonMises)
chresp      = @(ori,Se,ch) ...
                sumnorm(exp(dSd2k(Se).*(cosd(2*ch-(2*ori))-1)));
% uniform distribution over orientation channels
uniform     = ones(size(ch))./numel(ch);
% decoding function (mean of the posterior)
decoder     = @(input, ch) mod(rad2deg(angle(sum(exp(1j * deg2rad(2*ch)) .* input))) / 2, 180);
% exponential decay function
decay       = @(x,tau) (exp(x.*-1*(1./tau)));
% n-back shifter
nbkn        = @(x,n) [NaN(n,1); x(1:end-n)];   
% fill memory buffer with previous posteriors
fillbf      = @(x,y) [y x(:,1:end-1)]; 
% transition model from van Bergen & Jehee 2019; Fritsche & al., 2020
tmodel      = @(x) exp((-1./(2.*Sd.^2)).*abs(mod(x+90,180)-90).^2);

%% run the model
history     = uniform;                    % first trial, no history
decision    = zeros(trials,1);
posterior_s = decision;
buffer      = repmat(uniform',[1,nback]); % uniform weigths in memory
%--------------------------------------------------------------------------
d           = tmodel(ch-90); d = d./sum(d,2);
tr_prior    = Pt.*d+(1-Pt).*uniform;  
%--------------------------------------------------------------------------
for k = 1:trials
    if numel(Se)>1
        if meas~=0
            theta_k     = circ_vmrnd(deg2rad(2*theta(k)), dSd2k(meas(k)), 1);
            theta_k     = mod(rad2deg(theta_k)/2,180);
        else
            theta_k     = theta(k);
        end
        encoding        = chresp(theta_k,Se(k),ch).*history;
    else
        if meas~=0
            theta_k     = circ_vmrnd(deg2rad(2*theta(k)), dSd2k(meas), 1);
            theta_k     = mod(rad2deg(theta_k)/2,180);
        else
            theta_k     = theta(k);
       end
        encoding        = chresp(theta_k,Se,ch).*history;
    end
    decision(k,:) =  decoder(encoding',ch');
    [~, s0]       = circ_std(deg2rad(2*ch'), encoding');
    posterior_s(k)= rad2deg(s0)/2;
          
    %----------------------------------------------------------------------
    % adapted from Fritsche et al., 2020, update prior:
    prior         = cconv(encoding,tr_prior,numel(ch));
    prior         = circshift(prior,round(numel(ch)/2),2);
    prior         = prior/trapz(ch-90,prior);
    buffer        = fillbf(buffer, prior');
    %----------------------------------------------------------------------
    % weighted average of previous n-back trials
    wdecay        = decay(1:nback,tau);
    history       = sumnorm(sum(wdecay.*buffer,2)');
end

model.delta   = sdp_acute_ang(nbkn(theta,1)-theta);
model.error   = sdp_acute_ang(decision-theta);
model.decoded = decision;
model.theta   = theta;
model.sigma   = posterior_s;

end