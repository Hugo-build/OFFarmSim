function [H0, V0] = getTension2ends(cable, X2F_local)

kN0 = find(cable.HH(1,:));
H01 = interp1(unique(cable.XXF2F(kN0)), unique(cable.HH(1,kN0)), X2F_local);
if cable.Z2F == 0
    H02=H01;
    V01 = cable.w*cable.s'/2;
    V02=V01;
else
    V01 = interp1(unique(cable.XXF2F(kN0)), unique(cable.VV(1,kN0)), X2F_local);
    kN0 = find(cable.HH(2,:));
    H02 = interp1(unique(cable.XXF2F(kN0)), unique(cable.HH(2,kN0)), X2F_local);
    V02 = interp1(unique(cable.XXF2F(kN0)), unique(cable.VV(2,kN0)), X2F_local);
end

H0 = [H01;H02];
V0 = [V01;V02];

end