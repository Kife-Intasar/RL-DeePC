function names = available_benchmarks(group)

all_names = { ...
    'massspring', ...
    'rcbuilding', ...
    'aircraftpitch'
    };

if nargin < 1
    group = 'all';
end
end
