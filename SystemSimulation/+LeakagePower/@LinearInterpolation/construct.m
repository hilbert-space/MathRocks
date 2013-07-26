function output = construct(this, Lgrid, Tgrid, Igrid, options)
  output.F = griddedInterpolant( ...
    Lgrid.', Tgrid.', Igrid.', 'linear', 'none');
end
