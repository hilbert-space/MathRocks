function options = technologicalProcess(options)
  processParameters = options.get('processParameters', { 'Leff', 'Tox' });
  if ~isa(processParameters, 'Options')
    processParameters = Options(processParameters, []);
  end

  names = fieldnames(processParameters);
  for i = 1:length(names)
    parameter = processParameters.(names{i});
    if isempty(parameter), parameter = Options; end

    %
    % According to the technology requirements published by ITRS 2011,
    % the critical dimensions (CDs) should be controlled within 12%.
    %
    % Since about 99.7% of values drawn from a Gaussian distribution are
    % within three standard deviatiosn away from the mean, we let
    %
    %  3 * sigma = 0.12 * mu, that is,
    %
    %  sigma = 0.12 * mu / 3 = 0.04 * mu.
    %
    % Reference:
    %
    % http://www.itrs.net/Links/2011ITRS/2011Tables/Design_2011Tables.xlsx
    % (see Table DESN10)
    %
    % https://en.wikipedia.org/wiki/Normal_distribution#Standard_deviation_and_tolerance_intervals
    %

    switch names{i}
    case 'Leff'
      nominal = 22.5e-9;
    case 'Tox'
      nominal = 1e-9;
    otherwise
      assert(false);
    end

    parameter.nominal = nominal;
    parameter.sigma = 0.04 * nominal;
    parameter.range = nominal + [ -3, 3 ] * parameter.sigma; % see above
    parameter.reference = nominal;

    processParameters.(names{i}) = parameter;
  end

  options.processParameters = processParameters;
end