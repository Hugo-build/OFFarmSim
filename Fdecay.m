function F = Fdecay(t, Fcons, Tcons, Tramp)
   % --- Decay test -------------------
    if t < Tramp
        F = Fcons/Tramp*t;
    elseif t>=Tramp && t<=Tcons
        F = Fcons;
    elseif t> Tcons
        F = 0*Fcons;
    end
   % ----------------------------------
end