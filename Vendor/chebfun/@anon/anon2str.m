function s = anon2str(varargin)
%ANON2STR Convert the function field in anons to a pretty string for a
%   single anon (i.e. don't do anything recursive). This is a wrapper for
%   FUNC2STR method for anons.
if nargin == 1
    s = func2str(varargin{1});
else
    s = func2str(varargin{1},varargin{2});
end