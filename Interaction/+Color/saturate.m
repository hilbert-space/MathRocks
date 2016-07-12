function color = saturate(color, change)
  R = color(1);
  G = color(2);
  B = color(3);

  Pr = .299;
  Pg = .587;
  Pb = .114;

  P = sqrt(R * R * Pr + G * G * Pg + B * B * Pb);

  R = P + (R - P) * change;
  G = P + (G - P) * change;
  B = P + (B - P) * change;

  color = [R, G, B];
end
