function profile(varargin)
  output = Debug.startProfile;
  feval(varargin{:});
  Debug.stopProfile(output);
end
