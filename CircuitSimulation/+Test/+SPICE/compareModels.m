function compareModels
  cards = struct;

  a = SPICE.configure('Circuits/include/models/45nm_HP.pm');
  cards.NMOS_HP = a.nmos;
  cards.PMOS_HP = a.pmos;

  a = SPICE.configure('Circuits/include/models/45nm_LP.pm');
  cards.NMOS_LP = a.nmos;
  cards.PMOS_LP = a.pmos;

  a = SPICE.configure('Circuits/include/models/NMOS_THKOX.inc');
  cards.NMOS_THKOX = a.nmos_thkox;
  a = SPICE.configure('Circuits/include/models/PMOS_THKOX.inc');
  cards.PMOS_THKOX = a.pmos_thkox;

  a = SPICE.configure('Circuits/include/models/NMOS_VTG.inc');
  cards.NMOS_VTG = a.nmos_vtg;
  a = SPICE.configure('Circuits/include/models/PMOS_VTG.inc');
  cards.PMOS_VTG = a.pmos_vtg;

  a = SPICE.configure('Circuits/include/models/NMOS_VTH.inc');
  cards.NMOS_VTH = a.nmos_vth;
  a = SPICE.configure('Circuits/include/models/PMOS_VTH.inc');
  cards.NMOS_VTH = a.pmos_vth;

  a = SPICE.configure('Circuits/include/models/NMOS_VTL.inc');
  cards.NMOS_VTL = a.nmos_vtl;
  a = SPICE.configure('Circuits/include/models/PMOS_VTL.inc');
  cards.NMOS_VTL = a.pmos_vtl;

  SPICE.compare(cards);
end
