function F = Fdummy(t,x,ndof,simTime)

persistent upd


     F = zeros(ndof,1); 
     switch nargin
         case 4
             if t==0
                 upd = textprogressbar(round(simTime(end)));
             end
             upd(round(t));
     end

% persistent vHistory
% persistent tHistory
%      if t==0
%         vHistory = x(length(x)/2+1:length(x));
%         tHistory = 0;
%      else
%         vHistory = [vHistory, x(length(x)/2+1:length(x))];
%         tHistory = [tHistory, t];
%      end

end