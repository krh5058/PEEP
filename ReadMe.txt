140219

Repo initialized

Contents: ReadMe.txt, batch140219.m
Ignored: Client provided files

Assessment:
1/31/14

Project ID: PEEP
Contact: AMANDA LYNEE THOMAS <alt5225@psu.edu>, Rick Gilmore <thatrickgilmore@gmail.com>

Preliminary assessment:
- Request for automated formatting of data output
- Experimental design includes three passive listening conditions (ang, neu, hap)
- Order is counterbalanced and logged.
- Onset times are logged.
- Behavioral ratings (Likert) for each listening presentation are made by participant.
- Formatting required for FSL (FEAT):
- Plain-text
- 1 file per presentation
- 3 columns
Onset in seconds
Duration in seconds, optional “1” if multiple events with identical durations
Modulated magnitude of expected response
- FEAT analysis parameters:
- General linear model
- First-level analyses
- Custom (3 column format)
- EV = 3
- No temporal derivative

Project goals:
- Write script to automate data organization between onset time, duration, and behavioral ratings.
- Follow FSL timing input formatting
- Verify script appropriately contributes to analysis workflow

Necessary materials:
- Example dataset:
- Order, onset timing, and ratings.
- Verification that switch statement is up-to-date (found in peep_play_13_06_11.m\data_parse):
    switch emo_type
        case 'ang'
            fprintf( fid_ang, '%3.3f%s%3.3f%s%d\n', onset, field_sep, duration, field_sep, 1 );
            fprintf( fid_snd, '%3.3f%s%3.3f%s%d\n', onset, field_sep, duration, field_sep, 1 );
        case 'hap'
            fprintf( fid_hap, '%3.3f%s%3.3f%s%d\n', onset, field_sep, duration, field_sep, 1 );
            fprintf( fid_snd, '%3.3f%s%3.3f%s%d\n', onset, field_sep, duration, field_sep, 1 );
        case 'neu'
            fprintf( fid_neu, '%3.3f%s%3.3f%s%d\n', onset, field_sep, duration, field_sep, 1 );
            fprintf( fid_snd, '%3.3f%s%3.3f%s%d\n', onset, field_sep, duration, field_sep, 1 );
        case 'sil'
            fprintf( fid_sil, '%3.3f%s%3.3f%s%d\n', onset, field_sep, duration, field_sep, 1 );
        otherwise
            error('Emotion type not recognized.\n');
    end

Timeline:
- Tentative

