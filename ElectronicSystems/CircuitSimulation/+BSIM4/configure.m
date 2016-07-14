function config = configure(L, W, card)
  config.L = L;
  config.W = W;

  NF = 1;

  Lnew = L + card.xl;
  Wnew = W / NF + card.xw;

  T0 = Lnew.^card.lln;
  T1 = Wnew.^card.lwn;
  dL = card.lint + ...
    card.ll ./ T0 + ...
    card.lw ./ T1 + ...
    card.lwl ./ (T0 .* T1);

  T2 = Lnew.^card.wln;
  T3 = Wnew.^card.wwn;
  dW = card.wint + ...
    card.wl ./ T2 + ...
    card.ww ./ T3 + ...
    card.wwl ./ (T2 .* T3);

  config.Leff = Lnew - 2.0 * dL;
  config.Weff = Wnew - 2.0 * dW;

  %
  % Perimeters and areas of the source and drain
  %
  WeffCJ = Wnew - 2 * card.dwj;

  [config.Ps, config.Pd, config.As, config.Ad] = BSIM4.computeGeometry( ...
    NF, card.geomod, card.min, WeffCJ, card.dmcg, card.dmci, card.dmdg);
end
