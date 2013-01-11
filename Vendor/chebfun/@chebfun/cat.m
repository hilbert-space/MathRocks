function out = cat(dim,varargin)
% CAT   Concatenate chebfun arrays.
% 
% CAT(DIM,A,B) concatenates the arrays A and B along the dimension DIM 
% where DIM is either 1 or 2.  
% CAT(2,A,B) is the same as [A,B].
% CAT(1,A,B) is the same as [A;B].
%
% B = CAT(DIM,A1,A2,A3,A4,...) concatenates the input arrays A1, A2, 
% etc. along the dimension DIM.
%     
% See also horzcat, vertcat.

if isempty(dim)
    error('CHEBFUN:cat:dim',['Dimension must be a finite integer.\n',...
    '\n',...
    ' )\\_/(    Meow\n',...
    ' (o.o)\n',...
    ' (_|_)_/']);
end

if nargin < 3
    error('CHEBFUN:cat:nargin','Not enough input arguments.');
end
    
if dim == 1
    out = vertcat(varargin{:});
elseif dim == 2
    out = horzcat(varargin{:});
else
    error('CHEBFUN:cat:dim12','Dimension must 1 or 2.')
end
