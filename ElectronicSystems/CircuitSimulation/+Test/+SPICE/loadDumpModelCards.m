function loadDumpModelCards
  cards = struct;
  a = SPICE.loadModelCards(getSource('45nm_HP.pm'));
  cards.nmos = a.nmos;
  cards.pmos = a.pmos;
  SPICE.dumpModelCards(cards, getDestination('HP.sp'));

  cards = struct;
  a = SPICE.loadModelCards(getSource('45nm_LP.pm'));
  cards.nmos = a.nmos;
  cards.pmos = a.pmos;
  SPICE.dumpModelCards(cards, getDestination('LP.sp'));

  cards = struct;
  a = SPICE.loadModelCards(getSource('NMOS_THKOX.inc'));
  cards.nmos = a.nmos_thkox;
  a = SPICE.loadModelCards(getSource('PMOS_THKOX.inc'));
  cards.pmos = a.pmos_thkox;
  SPICE.dumpModelCards(cards, getDestination('THKOX.sp'));

  cards = struct;
  a = SPICE.loadModelCards(getSource('NMOS_VTG.inc'));
  cards.nmos = a.nmos_vtg;
  a = SPICE.loadModelCards(getSource('PMOS_VTG.inc'));
  cards.pmos = a.pmos_vtg;
  SPICE.dumpModelCards(cards, getDestination('VTG.sp'));

  cards = struct;
  a = SPICE.loadModelCards(getSource('NMOS_VTH.inc'));
  cards.nmos = a.nmos_vth;
  a = SPICE.loadModelCards(getSource('PMOS_VTH.inc'));
  cards.pmos = a.pmos_vth;
  SPICE.dumpModelCards(cards, getDestination('VTH.sp'));

  cards = struct;
  a = SPICE.loadModelCards(getSource('NMOS_VTL.inc'));
  cards.nmos = a.nmos_vtl;
  a = SPICE.loadModelCards(getSource('PMOS_VTL.inc'));
  cards.pmos = a.pmos_vtl;
  SPICE.dumpModelCards(cards, getDestination('VTL.sp'));
end

function name = getSource(name)
  name = File.join('Circuits', 'sources', name);
end

function name = getDestination(name)
  name = File.join('Circuits', 'include', 'models', name);
end
