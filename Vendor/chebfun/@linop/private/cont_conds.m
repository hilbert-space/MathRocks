function [Cmat,c] = cont_conds(A,Nsys,map,bks)
% Retrieve continuity conditions for a piecewise linop

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

jumpinfo = A.jumpinfo;
difforder = A.difforder;
N = [Nsys{:}];
syssize = numel(Nsys);

% Initialise
Cmat = zeros(1,sum(N)); bcrownum = 1; intnum = 1; csN = cumsum([0 N]);  
% Apply continuity conditions for piecewise intervals
for k = 1:syssize

    % Setup 
    bk = bks{k};
    numfunsk = numel(bk)-1;   % # of intervals in this variable
    if numfunsk <= 1           % Nothing to do here (no breaks)
        intnum = intnum + 1;    
        continue
    end
    dok = max(difforder(:,k)); % Difforder for this variable
    Nsysk = Nsys{k};           % # of points in each interval
    csNsysk = cumsum([0 Nsysk]);

    % Make the diffmats for piecewise boundary conditions.
    if dok > 1
        D = zeros(sum(Nsysk),sum(Nsysk),dok-1);
        domk = domain(bk([1 end]));
        D(:,:,1) = feval(diff(domk),Nsysk,map,bk);
        for l = 2:dok-1
%               D(:,:,ll) = D(:,:,1)*D(:,:,ll-1);
          D(:,:,l) = feval(diff(domk,l),Nsysk,map,bk);
        end
    end

    % Extract the right rows
    for j = 1:numfunsk-1 % Continuity conditions
        
        if ~any(Nsysk(j+(0:1))), continue, end % Discretisation of size zero

        % Enforce continuity if there's no jump here
        if isempty(jumpinfo) || ~ismember([bk(j+1) k 0],jumpinfo,'rows')
            if Nsysk(j) && Nsysk(j+1)  
                idx = csN(intnum)+Nsysk(j)+(0:1);
                Cmat(bcrownum,idx) = [-1 1];
            elseif Nsysk(j) 
                idx = csN(intnum)+Nsysk(j);
                Cmat(bcrownum,idx) = -1;
            elseif Nsysk(j+1) 
                idx = csN(intnum)+Nsysk(j)+1;
                Cmat(bcrownum,idx) = 1;
            end
            bcrownum = bcrownum + 1;
        end

        % Get correct indices
        indxl = csNsysk(j)+(1:Nsysk(j));
        indxr = csNsysk(j+1)+(1:Nsysk(j+1));
        len = numel([indxl indxr]);

        % Derivative conditions
        for l = 1:dok-1   
            % Jump condition is being enforced here, so ignore
            if ~isempty(jumpinfo) && ismember([bk(j+1) k l],jumpinfo,'rows'), continue, end
            Dl = []; Dr = [];
            % No jump, enforce continuity
            if ~isempty(indxl)
                Dl = D(csNsysk(j+1),indxl,l);   % Left of break jj
            end
            if ~isempty(indxr)
                Dr = D(csNsysk(j+1)+1,indxr,l); % Right of break jj
            end
            idx = csN(intnum)+(1:len);        % Global row index
            Cmat(bcrownum,idx) = [-Dl Dr];    % Add to output
            bcrownum = bcrownum + 1;          % +1 bc counter
        end
        intnum = intnum + 1;                  % +1 interval counter

    end

    intnum = intnum + 1;                      % +1 interval counter

end

c = zeros(size(Cmat,1),1); % RHS of continuity conditions (no jumps)

% Why would this happen??
if numel(c) == 1 && ~any(Cmat)
    Cmat = []; c = []; return
end

end