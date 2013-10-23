function f = pointwiseFunction(f, varargin)
  f = char(f);
  f = regexprep(f, '([\^\*\/])', '.$1');

  arguments = '';
  pattern = '%s(:, %d)';

  k = 0;
  for i = 1:length(varargin)
    x = varargin{i};
    if ischar(x)
      switch x
      case 'column-wise'
        pattern = '%s(:, %d)';
      case 'row-wise'
        pattern = '%s(%d, :)';
      case 'element-wise'
        pattern = '%s(%d)';
      otherwise
        assert(false);
      end
      continue;
    end
    k = k + 1;
    variable = [ 'x', num2str(k) ];
    for j = 1:length(x)
      f = regexprep(f, ...
        sprintf('\\<%s\\>', char(x(j))), ...
        sprintf(pattern, variable, j));
    end
    if k == 1
      arguments = variable;
    else
      arguments = [ arguments, ',', variable ];
    end
  end

  f = str2func([ '@(', arguments, ')', f ]);
end
