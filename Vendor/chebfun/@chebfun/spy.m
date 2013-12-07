function spy(A)
% SPY   spy of a chebfun

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

hold off
[m,n] = size(A);
[a,b] = domain(A);
if isinf(a), a = -1e16; end
if isinf(b), b = 1e16; end
ee = (b-a)/100;
      
if isinf(m) && ~isinf(n)            % column quasimatrix
   for j = 1:n
      endsj = A(j).ends; 
      ss = repmat(endsj,3,1) + repmat([-ee ; NaN ; ee],1,length(endsj)); 
      ss = ss(:);
      ss([2:3 end-1:end]) = []; 
      ss(1) = a; ss(end) = b;
      jj = repmat(j,1,length(ss));
      plot(jj,ss,'-b'), hold on
   end
   set(gca,'ytick',[a b],'ydir','reverse')
   if n<10, 
       set(gca,'xtick',1:n)
   else
       set(gca,'xtick',[1 n]), 
   end
   axis([0 n+1 a b])
   ar = get(gca,'plotboxaspectratio');
   ar(1) = .5*ar(1);
   set(gca,'plotboxaspectratio',ar)
end

if ~isinf(m) && isinf(n)            % row quasimatrix
   for j = 1:m
      endsj = A(j).ends; 
      ss = repmat(endsj,3,1) + repmat([-ee ; NaN ; ee],1,length(endsj)); 
      ss = ss(:);
      ss([2:3 end-1:end]) = []; 
      ss(1) = a; ss(end) = b;
      jj = repmat(j,1,length(ss));
      plot(ss,jj,'-b'), hold on
   end
   set(gca,'xtick',[a b],'ydir','reverse')
   if m<10,
       set(gca,'ytick',1:m)
   else
       set(gca,'ytick',[1 m])
   end
   axis([a b 0 m+1])
   ar = get(gca,'plotboxaspectratio');
   ar(2) = .4*ar(2);
   set(gca,'plotboxaspectratio',ar)
end

hold off
