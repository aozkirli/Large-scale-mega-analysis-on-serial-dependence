function vec = sdp_acute_ang(vec)
%% Compute the acute angle
% Ambizione EPFL - PZ00P1_179988
%                                                  D.Pascucci    01.04.2020
%--------------------------------------------------------------------------
% vec         = mod(vec+90,180)-90;

    vec(vec>90)   = -(180-vec(vec>90));
    vec(vec<-90)  =  (180+vec(vec<-90));
end
