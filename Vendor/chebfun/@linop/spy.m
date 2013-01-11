function spy(A,c)
% SPY Visualize sparsity pattern.
%  SPY(S) plots the sparsity pattern of the linop S.
%
%  SPY(S,C) uses the color given by C.
%
%  Example:
%   d = domain(-1,.5,1);
%   spy([diff(d) 0 ; 1 diff(d,2)],'m')

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

ends = A.domain.endsandbreaks;
de = ends(end)-ends(1);
LW = 'linewidth'; lw = 3;
C = 'color'; EC = 'EdgeColor';
if nargin < 2, c = 'b'; end

N = 3;
Amat = feval(A,N,'nobc');
ish = ishold;


for j = 1:A.blocksize(1)
    for k = 1:A.blocksize(2)
        if ~A.iszero(j,k)
            NN = N*(numel(ends)-1);
            Ajk = Amat((j-1)*NN+(1:NN),(k-1)*NN+(1:NN));
            if A.isdiag(j,k)
                plot(ends([end 1])+(k-1)*de,-ends([end 1])-(j-1)*de,LW,lw,C,c); hold on
            else
                for l = 1:numel(ends)-1
                    fill(ends([l+1 l l l+1])+(k-1)*de,-ends([l+1 l+1 l l])-(j-1)*de,c,EC,c); hold on
                end
            end
        end
    end
end

% allends = [ends repmat([ends(1)+eps ends(2:end)],1,A.blocksize(1)-1)];
% tmp = repmat([0:A.blocksize(1)-1]*de,numel(ends),1);
% allends = unique(allends + [tmp(:)]');
% set(gca,'xTick',allends)
% set(gca,'yTick',-allends(end:-1:1))
% set(gca,'xTicklabel', ends )
% set(gca,'yTicklabel', ends )
% set(gca,'yTicklabel',str2num(get(gca,'xTicklabel')))

set(gca,'xTick',[])
set(gca,'yTick',[])

if ~ish, hold off, axis equal, axis tight, end






