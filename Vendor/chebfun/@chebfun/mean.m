function Fout = mean(F1,F2)
% MEAN   Average or mean value of chebfun.
%
% MEAN(F) is the mean value of the chebfun F.
%
% MEAN(F,G) is the average chebfun between chebfuns F and G.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

if nargin == 1
    
    if F1(1).trans
        Fout = transpose(mean(transpose(F1)));
    else
        if ~isempty(F1) && F1(1).funreturn
            Fout = chebconst;
        else
            Fout = zeros(1,size(F1,2));
        end
        for k = 1:size(F1,2)
            infends = isinf(F1(:,k).ends([1 end]));
            if infends == [1 0]
                Fout(k) = F1(:,k).imps(1);
            elseif infends == [0 1]
                Fout(k) = F1(:,k).imps(end);
            elseif infends == [1 1]
                if abs(F1(:,k).imps(1) - F1(:,k).imps(end)) < F1(:,k).scl
                    Fout(k) = F1(:,k).imps(1);
                else
                    Fout(k) = NaN;
                end
            else
                Fout(k) = sum(F1(:,k))/diff(F1(:,k).ends([1 end]));
            end
        end
    end
        
else
    
    Fout = (F1+F2)/2;
    
end
