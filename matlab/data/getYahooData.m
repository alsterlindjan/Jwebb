%% Funktion för data till Matlab, använd kommandon som 
% T = getYahooData("AAPL", datetime(2023,1,1), datetime(2024,1,1));

function T = getYahooData(ticker, startDate, endDate)

    arguments
        ticker (1,1) string
        startDate (1,1) datetime
        endDate (1,1) datetime
    end

    % --- UNIX timestamps ---
    p1 = floor(posixtime(startDate));
    p2 = floor(posixtime(endDate));

    % --- URL ---
    url = sprintf(['https://query1.finance.yahoo.com/v8/finance/chart/%s' ...
        '?period1=%d&period2=%d&interval=1d'], ...
        ticker, p1, p2);

    options = weboptions( ...
        'Timeout', 15, ...
        'HeaderFields', {'User-Agent','Mozilla/5.0'} ...
    );

    try
        data = webread(url, options);

        % --- Hantera result robust ---
        result = data.chart.result;
        
        if iscell(result)
            result = result{1};
        end

        % --- timestamps ---
        timestamps = result.timestamp;

        % --- quote ---
        quote = result.indicators.quote;
        if iscell(quote)
            quote = quote{1};
        end

        % --- adjclose ---
        hasAdj = isfield(result.indicators, 'adjclose');
        if hasAdj
            adj = result.indicators.adjclose;
            if iscell(adj)
                adj = adj{1};
            end
        end

        % --- Skapa tabell ---
        T = table;
        T.Date = datetime(timestamps, 'ConvertFrom', 'posixtime');

        T.Open  = quote.open(:);
        T.High  = quote.high(:);
        T.Low   = quote.low(:);
        T.Close = quote.close(:);
        T.Volume = quote.volume(:);

        if hasAdj
            T.AdjClose = adj.adjclose(:);
        else
            T.AdjClose = T.Close;
        end

        % --- Rensa ---
        T = rmmissing(T);
        T = sortrows(T, 'Date');

    catch ME
        error("Kunde inte hämta data från Yahoo (JSON API): %s", ME.message)
    end
end
