function varargout = cache(filename, f, varargin)
  if File.exist(filename)
    load(filename);
  else
    varargout = cell(1, nargout - 1);

    time = tic;
    [ varargout{:} ] = feval(f, varargin{:});
    varargout{end + 1} = toc(time);

    save(filename, 'varargout', '-v7.3');
  end
end
