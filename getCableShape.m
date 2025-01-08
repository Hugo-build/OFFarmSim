function [shapeLoc] = getCableShape(cable, X2F_local, H0, V0)

cable.s(cable.touchDownSeg) = interp1(unique(cable.XX2anch), unique(cable.SS), X2F_local);
% it is assumed that the first segment does not touch the sea bottom
shapeLoc.x = zeros(cable.Nnodes,1);
shapeLoc.z = zeros(cable.Nnodes,1);
shapeLoc.y = zeros(cable.Nnodes,1);
s = linspace(0,cable.s(1),cable.NnodesPerSeg(1));
for iseg = 1:cable.Nseg
    endNodes = [sum(cable.NnodesPerSeg(1:iseg)) - cable.NnodesPerSeg(iseg) + 1, ...
                sum(cable.NnodesPerSeg(1:iseg))];
    if iseg > 1
            s = [s, linspace(sum(cable.s(1:iseg-1)),sum(cable.s(1:iseg)),cable.NnodesPerSeg(iseg))];
    end
    for is = endNodes(1):1:endNodes(2)
            [shapeLoc.x(is), shapeLoc.z(is)] = Catenary(H0, ...
                V0+cable.w(iseg)*cable.s(iseg)-cable.w(1:iseg)*cable.s(1:iseg)',...
                cable.w(iseg), s(is)-s(endNodes(1)), cable.E(iseg), cable.A(iseg));
            if iseg == 1
            else
                shapeLoc.x(is) = shapeLoc.x(is) +  shapeLoc.x(endNodes(1)-1);
                shapeLoc.z(is) = shapeLoc.z(is) +  shapeLoc.z(endNodes(1)-1);
            end
    end
    
end
if cable.length>sum(cable.s(1:end))
        shapeLoc.x = [shapeLoc.x; cable.length-sum(cable.s(1:end))+shapeLoc.x(endNodes(2))];
        shapeLoc.y = [shapeLoc.y; 0];
        shapeLoc.z = [shapeLoc.z; -abs(cable.Z2F)];
end 
end