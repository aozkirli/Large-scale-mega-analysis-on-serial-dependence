function x = nbk(x,n)
%% Back- , Forward-shift operator
% Ambizione EPFL - PZ00P1_179988
%                                                  D.Pascucci    01.04.2020
%--------------------------------------------------------------------------
if n<0 % future
    x   = [x(abs(n)+1:end);NaN(abs(n),1)];
else
    x   = [NaN(n,1); x(1:end-n)];
end

