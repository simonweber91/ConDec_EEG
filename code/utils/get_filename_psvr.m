function filename = get_filename_psvr(i_sub, p, i_event, i_band, i_label, i_coh)

sub_str = ['sub-' num2str(i_sub, '%02i')];

event = p.psvr.event{i_event};
band = p.psvr.bands{i_band};
label = p.psvr.labels{i_label};
coh = p.data.coherences{i_coh};

filename = [sub_str '_psvr_' event '_' band '_' label '_' coh '_' num2str(p.psvr.n_perm) 'perm'];

