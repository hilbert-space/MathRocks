function Barber
  %
  % Reference:
  %
  % D. Barber. Bayesian Reasoning and Machine Learning.
  % Cambridge University Press, 2013.
  %
  % http://web4.cs.ucl.ac.uk/staff/D.Barber
  %

  clear all;
  close all;

  setup;

  params = [ 1, 2, 2 ];

  xTrain = [ (-0.75 + rand(1, 20)) (0.75 + rand(1, 20)) ]';
  nodeCount = length(xTrain);
  yTrain = sin(4 * xTrain) + 0.1 * randn(nodeCount, 1);

  xTest = (-4:0.1:4)';

  kernel = Options( ...
    'compute', @correlate, 'parameters', params);

  surrogate = Regression.GaussianProcess( ...
    'nodes', xTrain, 'responses', yTrain, ...
    'kernel', kernel, 'noiseVariance', 0.0001, ...
    'verbose', true);

  [ yTest, yTestVar ] = surrogate.evaluate(xTest);
  yTestVar = diag(yTestVar);

  figure

  plot(xTest, yTest, 'r-');
  hold on;

  plot(xTest, yTest - sqrt(yTestVar), 'g-');
  plot(xTest, yTest + sqrt(yTestVar), 'g-');
  plot(xTrain, yTrain, '.');
end

function k = correlate(x, y, params)
  a = params(1);
  b = params(2);
  c = params(3);
  k = a * exp(- b * sum((x - y).^2, 1).^(0.5 * c));
end
