function r = choose_energy_rank(s, energy)

if isempty(s) || all(s <= 0)
    r = 1;
    return;
end
s = real(s(:));
cs = cumsum(s) / max(sum(s), eps);
r = find(cs >= energy, 1, 'first');
if isempty(r), r = numel(s); end
end
