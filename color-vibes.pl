% color-vibes.pl

% example keywords: calm, cozy, energetic, romantic, mysterious
% color-properties: hue?, warmth/cool, saturation, brightness

% FACTS

% color hue keyword weights

% color(red, [calm-10, cozy-30, energetic-85, romantic-100, mysterious-30]).
% color(orange, [calm-15, cozy-95, energetic-85, romantic-40, mysterious-15]).
% color(yellow, [calm-20, cozy-85, energetic-90, romantic-30, mysterious-10]).
% color(green, [calm-90, cozy-85, energetic-70, romantic-5, mysterious-90]).
% color(blue, [calm-100, cozy-40, energetic-60, romantic-20, mysterious-100]).
% color(purple, [calm-80, cozy-40, energetic-80, romantic-80, mysterious-90]).

% RULES

% Keyword-to-property ranges
keyword_properties(calm, hue(180-240), warmth(20-40), saturation(20-50), brightness(50-80)).
keyword_properties(cozy, hue(15-60), warmth(60-80), saturation(50-70), brightness(60-90)).
keyword_properties(energetic, hue(0-60), warmth(80-100), saturation(80-100), brightness(70-100)).
keyword_properties(romantic, hue(300-30), warmth(70-90), saturation(60-80), brightness(50-70)).
keyword_properties(mysterious, hue(240-300), warmth(20-40), saturation(40-70), brightness(30-60)).


% Extract a specific range for a given property
extract_keyword_range(Keyword, Property, Range) :-
    keyword_properties(Keyword, Hue, Warmth, Saturation, Brightness),
    ( Property = hue -> Range = Hue
    ; Property = warmth -> Range = Warmth
    ; Property = saturation -> Range = Saturation
    ; Property = brightness -> Range = Brightness
    ).

% Combine multiple ranges for a given property
combine_ranges(Keywords, Property, CombinedRange) :-
    findall(Range, (
        member(Keyword, Keywords),
        extract_keyword_range(Keyword, Property, Range)
    ), Ranges),
    ( Property = hue ->
        merge_wrapped_hue_ranges(Ranges, CombinedRange)
    ; merge_ranges(Ranges, CombinedRange)
    ).

% Merge a list of non-hue ranges into a single range
merge_ranges(Ranges, Low-High) :-
    findall(LowValue, member(LowValue-_, Ranges), Lows),
    findall(HighValue, member(_-HighValue, Ranges), Highs),
    min_list(Lows, Low),
    max_list(Highs, High).

merge_wrapped_hue_ranges([], 0-0). % Base case: empty input

merge_wrapped_hue_ranges(Ranges, CombinedRange) :-
    % Adjust ranges to handle wrapping
    wrap_adjusted_ranges(Ranges, AdjustedRanges),
    % Find the minimum and maximum values
    findall(Low, member(Low-_, AdjustedRanges), Lows),
    findall(High, member(_-High, AdjustedRanges), Highs),
    min_list(Lows, MinLow),
    max_list(Highs, MaxHigh),
    % Combine the adjusted ranges
    CombinedRange = MinLow-MaxHigh.

% Check if a range is non-wrapping
non_wrapping_range(Low-High) :- Low =< High.

wrap_adjusted_ranges([], []). % Base case: empty input

wrap_adjusted_ranges([Low-High | Rest], [AdjustedLow-AdjustedHigh | AdjustedRest]) :-
    ( Low =< High -> % Non-wrapping range
        AdjustedLow = Low,
        AdjustedHigh = High
    ; % Wrapping range: add 360 to the high value
        AdjustedLow = Low,
        AdjustedHigh is High + 360
    ),
    wrap_adjusted_ranges(Rest, AdjustedRest).


% Calculate final ranges for a list of keywords
calculate_palette_ranges(Keywords, final_ranges(Hue, Warmth, Saturation, Brightness)) :-
    combine_ranges(Keywords, hue, Hue),
    combine_ranges(Keywords, warmth, Warmth),
    combine_ranges(Keywords, saturation, Saturation),
    combine_ranges(Keywords, brightness, Brightness).





