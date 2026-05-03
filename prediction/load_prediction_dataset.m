function ds = load_prediction_dataset(name, rootdir)
%LOAD_PREDICTION_DATASET Load official Section 1 benchmark data.
if nargin < 2 || isempty(rootdir)
    rootdir = fileparts(fileparts(mfilename('fullpath')));
end
pred_dir = fullfile(rootdir,'data','benchmarks','Prediction');
name = lower(strrep(name,' ','_'));

ds = struct('name',name,'cases',[],'unit','','title','');

switch name
    case 'silverbox'
        S = load(fullfile(pred_dir,'silverbox_official.mat'));
        ds.unit = 'mV'; ds.title = 'Silverbox';
        ds.cases = [ ...
            local_case('silverbox_test_multisine', S.train_u, S.train_y, S.test1_u, S.test1_y, S.test1_init_len); ...
            local_case('silverbox_test_arrow_full', S.train_u, S.train_y, S.test2_u, S.test2_y, S.test2_init_len); ...
            local_case('silverbox_test_arrow_no_extrapolation', S.train_u, S.train_y, S.test3_u, S.test3_y, S.test3_init_len) ...
            ];
    case 'emps'
        S = load(fullfile(pred_dir,'emps_official.mat'));
        ds.unit = 'ticks/s'; ds.title = 'EMPS';
        ds.cases = local_case('emps_test', S.train_u, S.train_y, S.test_u, S.test_y, S.test_init_len);
    case {'cascaded_tanks','cascaded tanks'}
        S = load(fullfile(pred_dir,'cascaded_tanks_official.mat'));
        ds.unit = 'V'; ds.title = 'Cascaded Tanks';
        ds.cases = local_case('cascaded_tanks_test', S.train_u, S.train_y, S.test_u, S.test_y, S.test_init_len);
    case 'ced'
        S = load(fullfile(pred_dir,'ced_official.mat'));
        train_u = [double(S.train1_u(:)); double(S.train2_u(:))];
        train_y = [double(S.train1_y(:)); double(S.train2_y(:))];
        if isfield(S,'extra_train_u') && isfield(S,'extra_train_y')
            train_u = [train_u; double(S.extra_train_u(:))];
            train_y = [train_y; double(S.extra_train_y(:))];
        end
        ds.unit = 'mm'; ds.title = 'Coupled Electric Drives';
        ds.cases = [ ...
            local_case('ced_test_low', train_u, train_y, double(S.test1_u(:)), double(S.test1_y(:)), S.test1_init_len); ...
            local_case('ced_test_high', train_u, train_y, double(S.test2_u(:)), double(S.test2_y(:)), S.test2_init_len) ...
            ];
    case {'wiener_hammerstein','wienerhammerstein','wh'}
        S = load(fullfile(pred_dir,'wiener_hammerstein_official.mat'));
        ds.unit = '';
        ds.title = 'Wiener-Hammerstein';
        ds.cases = local_case('wiener_hammerstein_test', ...
            S.train_u, S.train_y, S.test_u, S.test_y, S.test_init_len);
    otherwise
        error('Unknown prediction dataset: %s', name);
end
end

function c = local_case(name, train_u, train_y, test_u, test_y, init_len)
c = struct();
c.name = name;
c.train_u = double(train_u(:));
c.train_y = double(train_y(:));
c.test_u = double(test_u(:));
c.test_y = double(test_y(:));
c.init_len = double(init_len(1));
end
