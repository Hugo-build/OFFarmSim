function reshapedData = reshapeRadiation(data,numDoF)
    numOmega = size(data, 1);
    if any(size(data) == numDoF)
        iDim_omega = find(size(data) ~= numDoF);
        iDim_DoF = find(size(data) == numDoF);
        reshapedData = reshape(data, [size(data, iDim_omega), ...
                                      size(data, iDim_DoF(1)) * size(data, iDim_DoF(2))]);
    elseif any(size(data) == numDoF^2)
        reshapedData = data;
    else
        error(['The Dimension of the freq-dependent Added mass\n '  ...
               'does not match the DoFs of the floating body']);
    end
end