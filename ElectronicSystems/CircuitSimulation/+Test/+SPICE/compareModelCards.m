function compareModelCards
  setup;

  nCards = struct;
  pCards = struct;

  a = SPICE.loadModelCards('Circuits/sources/45nm_HP.pm');
  nCards.NMOS_HP = a.nmos;
  pCards.PMOS_HP = a.pmos;

  a = SPICE.loadModelCards('Circuits/sources/45nm_LP.pm');
  nCards.NMOS_LP = a.nmos;
  pCards.PMOS_LP = a.pmos;

  a = SPICE.loadModelCards('Circuits/sources/NMOS_THKOX.inc');
  nCards.NMOS_THKOX = a.nmos_thkox;
  a = SPICE.loadModelCards('Circuits/sources/PMOS_THKOX.inc');
  pCards.PMOS_THKOX = a.pmos_thkox;

  a = SPICE.loadModelCards('Circuits/sources/NMOS_VTG.inc');
  nCards.NMOS_VTG = a.nmos_vtg;
  a = SPICE.loadModelCards('Circuits/sources/PMOS_VTG.inc');
  pCards.PMOS_VTG = a.pmos_vtg;

  a = SPICE.loadModelCards('Circuits/sources/NMOS_VTH.inc');
  nCards.NMOS_VTH = a.nmos_vth;
  a = SPICE.loadModelCards('Circuits/sources/PMOS_VTH.inc');
  pCards.PMOS_VTH = a.pmos_vth;

  a = SPICE.loadModelCards('Circuits/sources/NMOS_VTL.inc');
  nCards.NMOS_VTL = a.nmos_vtl;
  a = SPICE.loadModelCards('Circuits/sources/PMOS_VTL.inc');
  pCards.PMOS_VTL = a.pmos_vtl;

  fprintf('NMOS\n');
  fprintf('%s', repmat('=', 1, 10 + length(fieldnames(nCards)) * 15));
  fprintf('\n');
  SPICE.compareModelCards(nCards);
  fprintf('\n');

  fprintf('PMOS\n');
  fprintf('%s', repmat('=', 1, 10 + length(fieldnames(pCards)) * 15));
  fprintf('\n');
  SPICE.compareModelCards(pCards);
end
