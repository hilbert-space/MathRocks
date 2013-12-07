function plot(f,varargin)
%PLOT Plot a fun2
% 
%  A very basic plot command mainly for use by developers. 

% Copyright 2013 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

surf(f,'facecolor','interp',varargin{:})