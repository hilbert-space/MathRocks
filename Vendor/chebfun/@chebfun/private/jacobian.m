function [J constInfo] = jacobian(F,u)
% JACOBIAN returns the Jacobian (or Frechet derivatives) of chebfuns.
%
% J = jacobian(F,u) returns the Jacobian of the chebfun F with respect to
% the chebfun u. Both F and u can be a quasimatrix.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

% Obtain a list of all ID-s of the chebfun u (concat. the list if u is a
% quasimatrix
IDlist = cat(1,u.ID);

% Initialize the Jacobian, we will fill it up recursively
J = []; constInfo = [];
for k = 1:numel(F)
    % Check whether a ID of F matches an ID of u. If not, we need to go one
    % step further back up in the evaluation trace. If we however have a
    % match, we have gotten to the "ground level", so we reset the Jacobian
    % to be the appropriate "semi-identity" chebop (i.e. a chebop that is
    % the identity chebop in one block and the zero chebop in other
    % blocks). The resetting of the Jacobians is done below in the function
    % jacResetFun.
    idx = find((F(k).ID(1) == IDlist(:,1)) == (F(k).ID(2) == IDlist(:,2)));
    if isempty(idx)
        % Using subsref and feval for anons
        [row cInfoRow] = F(k).jacobian(u);
    else
        block = eye(domain(F(k)));
        cInfoBlock = 0;
        numu = numel(u);
        
        
        if numu > 1
            blockLeft = []; constInfoLeft = [];
            blockRight = []; constInfoRight = [];
            %             switch % !!! Thurfum ad tekka a u.trans
            for uCounter = 1:idx-1
                [blockTemp constInfoTemp] = jacobian(F(k),u(uCounter));
                blockLeft = [blockLeft blockTemp];
                constInfoLeft = [constInfoLeft constInfoTemp];
            end
            for uCounter = idx+1:numu
                [blockTemp constInfoTemp] = jacobian(F(k),u(uCounter));
                blockRight = [blockRight blockTemp];
                constInfoRight = [constInfoRight constInfoTemp];
            end
            row = [blockLeft, block, blockRight]; %jacResetFun(domain(F(k)),numu,idx);
            cInfoRow = [constInfoLeft cInfoBlock constInfoRight]; %zeros(1,numu);
        else
            row = block;
            cInfoRow = cInfoBlock;
        end
        
    end
    if isempty(row)
        row = repmat(zeros(domain(F(k))),1,numel(u));
        cInfoRow = zeros(1,numel(u));
    end
    J = [ J; row ];
    constInfo = [constInfo; cInfoRow];
end

function J =  jacResetFun(d,m,k) % Takes care of initializing Jacobians
I = eye(d);
Z = zeros(d);
J = [];
for j = 1:k-1
    J = [ J, Z ];
end
J = [ J, I ];
for j = k+1:m
    J = [ J, Z ];
end
