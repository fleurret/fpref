function filtCh1 = filterch(Ch1, Ch2)

% equalize gain
gain = rms(Ch1) / rms(Ch2);
Ch2 = Ch2 * (gain*2);

% is there a delay?
[sims, lags] = xcorr(Ch1, Ch2);
[~, idx] = max(abs(sims));
delay = lags(idx);

if delay > 0
    Ch2 = [zeros(delay, 1); Ch2(1:end-delay)];
elseif delay < 0
    delay = abs(delay);
    Ch2 = [Ch2(delay+1:end); zeros(delay,1)];
end

M = 512;
mu = 0.002;
eps = 1e-8;

N = length(Ch1);
w = zeros(M, 1);
filtCh1 = ones(N,1)*eps;

for i = M:N
    xvec = Ch2(i:-1:i-M+1);
    
    % echo
    echo = w' * xvec;
    
    % subtract
    filtCh1(i) = Ch1(i) - echo*100; % for some reason this works better idk
    
    % LMS update
    norm = xvec' * xvec + eps;
    w = w + (mu / norm) * filtCh1(i) * xvec;
end
