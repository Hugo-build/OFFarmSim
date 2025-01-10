function [H0, V0] = getTension(cable, X2F_local)

cable.s(cable.touchDownSeg) = interp1(unique(cable.XX2anch), unique(cable.SS), X2F_local);
% disp(cable.s); % For Debug
H0 = interp1(unique(cable.XX2anch), unique(cable.HH), X2F_local);
V0 = sum(cable.w(1:cable.touchDownSeg).*cable.s(1:cable.touchDownSeg));

end