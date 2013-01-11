function varargout = polyeigs(varargin)
%POLYEIGS   Polynomial chebop eigenvalue problem.
% [X,E] = POLYEIG(A0,A1,..,Ap,K) solves the polynomial eigenvalue problem
% of degree p:
%    (A0 + lambda*A1 + ... + lambda^p*Ap)*x = 0.
% The input is p+1 chebops, A0, A1, ..., Ap and the output is an inf-by-K
% chebfun quasimatrix, X, whose columns are the K least oscillatory
% eigenfunctions, and a vector of length k, E, whose elements are the
% eigenvalues.
%    for j = 1:K
%       lambda = E(j)
%       u = X(:,j)
%       A0(u) + lambda*A1(u) + ... + lambda^p*Ap(u) %is approximately 0.
%    end
%
% E = POLYEIGS(A0,A1,..,Ap,K) is a vector of length k whose elements are
% the K least oscillatory eigenvalues of the polynomial eigenvalue problem.
%
% EIGS(A0,A1,..,Ap,K,SIGMA) also finds K solutions to the polynomial
% eigenvalue problem. If SIGMA is a scalar, the eigenvalues found are the
% ones closest to SIGMA. Other possibilities are 'LR' and 'SR' for the
% eigenvalues of largest and smallest real part, and 'LM' (or Inf) and 'SM'
% for largest and smallest magnitude. SIGMA must be chosen appropriately
% for the given operator; for example, 'LM' for an unbounded operator will
% fail to converge!
%
% Similarly to CHEBOP/EIGS, this routine uses the built-in POLYEIG on dense
% matrices of increasing size, stopping when the targeted eigenfunctions
% appear to have converged, as determined by the chebfun constructor.
%
% Example:
%   A = chebop(@(x,u) diff(u,2),[-1 1],'dirichlet');
%   B = chebop(@(x,u) -x.*diff(u));
%   C = chebop(@(x,u) u);
%   [V D] = polyeigs(A,B,C,6,0)
%   plot(V)
%
% See also CHEBOP/EIGS, POLYEIG, LINOP/POLYEIGS.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

% Initialise
varin = varargin;
A = {};
k = 1;

% Parse the inputs
while ~isempty(varin)
    if isa(varin{1},'chebop')
        % Linearize and check whether the chebop is linear
        try
            A{k} = linop(varin{1});
            k = k+1;
            varin(1) = [];
        catch ME % Failure: Chebop was nonlinear
            if strcmp(ME.identifier,'CHEBOP:linop:nonlinear')
                error('CHEBOP:eigs',['Chebop appears to be nonlinear. Currently, polyeigs only' ...
                    '\nhas support for linear chebops.']);
            else
                rethrow(ME)
            end
        end
    elseif isa(varin{1},'linop')
        A{k} = varin{1};
        k = k+1;
        varin(1) = [];
    else
        break
    end
end
        
% Solve with LINOP/POLYEIGS
[varargout{1:nargout}] = polyeigs(A{:},varin{:});

end