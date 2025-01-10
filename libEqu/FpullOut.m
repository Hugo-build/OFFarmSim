function F = FpullOut(t, Fcons, Tramp)
    % --- Pull out test ---------------  
    F = Fcons;
    if t < Tramp
         F = Fcons/Tramp*t;
    end 
    % --------------------------------- 
end