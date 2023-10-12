function filename = get_filename_pp(i_sub, i_ses, identifier)

sub_str = ['sub-' num2str(i_sub, '%02i')];
ses_str = ['ses-' num2str(i_ses, '%02i')];

filename = [sub_str '_' ses_str '_task-condec_' identifier];