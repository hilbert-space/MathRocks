function dumpModelCards(cards, filename)
  file = fopen(filename, 'w');

  modelNames = fieldnames(cards);

  Tox = NaN;
  for i = 1:length(modelNames)
    model = cards.(modelNames{i});
    if isnan(Tox)
      Tox = model.toxp;
    else
      assert(Tox == model.toxp);
    end
  end

  fprintf(file, '.param Tox = %s\n', String(Tox));
  fprintf(file, '\n');

  for i = 1:length(modelNames)
    model = cards.(modelNames{i});

    fprintf(file, '.param Toxe%d = ''Tox + %s'' $ %s\n', i, ...
      String(model.toxe - Tox), String(model.toxe));
    fprintf(file, '.param Toxp%d = ''Tox'' $ %s\n', i, ...
      String(model.toxp));
    fprintf(file, '.param Toxm%d = ''Toxe%d'' $ %s\n', i, ...
      i, String(model.toxm));
    fprintf(file, '.param dTox%d = ''Toxe%d - Toxp%d'' $ %s\n', i, ...
      i, i, String(model.dtox));
    fprintf(file, '.param Toxref%d = ''Toxe%d'' $ %s\n', i, ...
      i, String(model.toxref));
    fprintf(file, '\n');
  end

  for i = 1:length(modelNames)
    model = cards.(modelNames{i});

    fprintf(file, '.model %s %s\n', modelNames{i}, model.type);

    parameterNames = sort(fieldnames(model));
    for j = 1:length(parameterNames)
      name = parameterNames{j};
      switch name
      case { 'toxe', 'toxp', 'toxm', 'dtox', 'toxref' }
        value = sprintf('''%s%d''', strrep(name, 't', 'T'), i);
        fprintf(file, '+ %s = %s\n', name, value);
      case 'type'
      otherwise
        value = String(model.(name));
        fprintf(file, '+ %s = %s\n', name, value);
      end
    end

    fprintf(file, '\n');
  end

  fclose(file);
end
