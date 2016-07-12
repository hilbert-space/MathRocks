function varargout = constructHotSpot(varargin)
  warning('The code has not been compiled yet. Trying to do so...');

  mex = sprintf('%s%sbin%smex', matlabroot, filesep, filesep);
  command = sprintf('cd %s; MEX="%s" make constructHotSpot', ...
    File.trace, mex);

  if system(command) ~= 0
    error('Cannot compile the HotSpot interface.');
  else
    error('The HotSpot interface has been successfully compiled. Rerun your code.');
  end

  clear all;
end
