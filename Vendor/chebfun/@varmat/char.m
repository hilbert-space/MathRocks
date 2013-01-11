function s = char(V,dom)
% CHAR  Convert varmat to pretty-print string.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information..

defreal = 6;

if isempty(V.defn)
  s = '   []';
else 
  if nargin == 1
      s1 = ['   with n = ',int2str(defreal),' realization:'];
      try
          Vmat = feval(V,defreal);
          M = max(max(abs(Vmat)));
          if (M > 1e2 || M < 1) && M ~= 0
              M = 10^round(log10(M)-1);
              Vmat = Vmat/M;
              s1 = [s1 sprintf('\n    %2.1e * ',M)];
          end
          s2 = num2str(Vmat,'  %8.4f');
      catch
          s2 = 'WARNING - varmat cannot be displayed. Possibly piecewise.';
      end
  else
      numints = numel(dom.endsandbreaks);
      defreal = max(2,ceil(defreal/(numints-1)));
      s1 = ['   with n = ',int2str(defreal),' realization:'];
      Vmat = feval(V,{defreal,[],dom});
      M = max(max(abs(Vmat)));
      if (M > 1e2 || M < 1) && M ~= 0
          M = 10^round(log10(M)-1);
          Vmat = Vmat/M;
          s1 = [s1 sprintf('\n    %2.1e * ',M)];
      end
      s2 = num2str(Vmat,'  %8.4f');
  end
  space = ' ';
  s2 = [ repmat(space,size(s2,1),5) s2 ];
  s = char(s1,'',s2);
end
  