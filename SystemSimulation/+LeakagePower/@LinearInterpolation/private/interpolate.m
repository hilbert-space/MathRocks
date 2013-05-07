function Vq = interpolate(X, Y, V, Xq, Yq)
  F = griddedInterpolant(X', Y', V', 'linear', 'none');
  Vq = (F(Xq.', Yq.')).';
end
