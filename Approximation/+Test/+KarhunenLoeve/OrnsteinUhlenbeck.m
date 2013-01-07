setup;

kl = KarhunenLoeve.OrnsteinUhlenbeck( ...
  'dimension', 3, 'domainBoundary', 1, 'correlationLength', 1);
plot(kl);