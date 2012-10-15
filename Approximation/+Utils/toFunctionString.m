function [ arguments, body ] = toFunctionString(p, varargin)
  %
  % Description:
  %
  %   Converts the given polynomial `p' to a function string with multiple
  %   vector-valued inputs formed according to the given sets of variables.
  %
  % Examples:
  %
  %   >> sympolys a0 a1 x1 x2 x3
  %   >> Utils.toFunctionString(a0*x2^2 + a0 + a1*x1 + x3^3, [ x1 x2 x3 ], [ a0 a1 ])
  %
  %   ans =
  %
  %   @(y1,y2)y2(1).*y1(2).^2 + y2(1) + y2(2).*y1(1) + y1(3).^3
  %
  %   >> Utils.toFunctionString(a0*x2^2 + a0 + a1*x1 + x3^3, [ x1 x2 x3 ], 'columns', [ a0 a1 ], 'rows')
  %
  %   ans =
  %
  %   @(y1,y2)y2(1,:).*y1(:,2).^2 + y2(1,:) + y2(2,:).*y1(:,1) + y1(:,3).^3
  %

  count = length(varargin);

  y = {};
  vars = {};
  args = {};

  pending = false;

  for i = 1:count
    subject = varargin{i};

    if ~ischar(subject)
      if pending
        [ vars, args ] = append(y, vars, args);
      end
      y{end + 1} = subject;
      pending = true;
    else
      [ vars, args ] = append(y, vars, args, subject);
      pending = false;
    end
  end

  if pending
    [ vars, args ] = append(y, vars, args);
  end

  count = length(y);

  if numel(vars) ~= count || numel(args) ~= count
    error('The numbers of elements do not match.');
  end

  if isa(p, 'sympoly')
    s = string(p, 'longg');
    s = regexprep(s, '\^', '.^');
    s = regexprep(s, '\*', '.*');
    s = regexprep(s, '\/', './');
  else
    f = matlabFunction(p);
    s = func2str(f);
    s = regexprep(s, '@\([^)]*\)', '');
  end

  for i = 1:count
    y0 = y{i};

    if numel(y0) == 1
      s = regexprep(s, [ '\<', char(y0(1)), '\>' ], sprintf(vars{i}, i));
    else
      for j = 1:numel(y0);
        s = regexprep(s, [ '\<', char(y0(j)), '\>' ], ...
          sprintf([ vars{i}, args{i} ], i, j));
      end
    end
  end

  iargs = 'y1';
  for i = 2:count
    iargs = [ iargs, sprintf(',y%d', i) ];
  end

  arguments = iargs;
  body = s;
end

function [ ovars, args ] = append(ivars, ovars, args, dir)
  ovars{end + 1} = 'y%d';
  if nargin > 3
    dir = lower(dir);
    switch (dir)
    case 'columns'
      args{end + 1} = '(:,%d)';
    case 'rows'
      args{end + 1} = '(%d,:)';
    otherwise
      error('The specified orientation is unknown.');
    end
  else
    args{end + 1} = '(%d)';
  end
end
