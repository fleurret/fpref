function plotcallraster(splist, range, color)

if nargin < 3
  color = 'b';
end

hold on

rows = length(splist);

for n = 1:rows
    trial = splist{n};
    block = range{n};
    
    calls = trial(trial > block(1) & trial < block(2));
    y = n/3;

    for i = 1:length(calls)
        set(line,...
            'XData',[1 1]*calls(i),...
            'YData',-[y y+0.25],...
            'Color', color{n},...
            'LineWidth', 1)
    end
end

hold off

set(gca,'YTickLabel',[])
