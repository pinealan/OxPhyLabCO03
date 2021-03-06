classdef CdfService < handle
% CdfHandle loads a dataset into memory
% This class provide handles to load and retrieve data from cdf dataset

properties
    nevmax;         % maximum number of events to process
    report;         % number of events between each console report
end

methods
    % constructor
    function this = CdfService()
        this.nevmax = 10000;
        this.report = 100;
    end

    % load data file into events array
    function [events, nev] = load(this, cdfFile)
        dataFile = CdfDataFile(cdfFile);
        events = CdfEvent(this.nevmax);
        nev = 0;

        fprintf(1, 'Begin loading\n');

        while 1
            ev = dataFile.next();
            if ev.isValid()
                nev = nev + 1;
                events(nev) = ev;
                if nev > this.nevmax                        
                    fprintf(1, 'Number of events reached maximum.\n');
                    break;
                end

                if mod(nev, this.report) == 0
                    fprintf(1, '%d events loaded\n', nev);
                end
            else
                fprintf(1, 'Reached the end of data file\n');
                break;
            end
        end

        events = events(1: nev);
        dataFile.close();
    end

    % get event from track object
    % @BAD terrible runtime, do not use this
    function event = getEventByTrack(~, events, track)
        for ev = events
            for trk = ev.tracks
                if trk == track
                    event = ev;
                    return;
                end
            end
        end
        event = -1;
    end

    % get event by id
    function event = getEventById(~, events, id)
        event = events(id);
    end

    % create data file from events array
    function createCdfDataFile(~, fileName, events)
        if ~ischar(fileName)
            return
        end

        f = fopen(fileName, 'w');

        for ev = events
            ntrk = size(ev.tracks, 2);
            fprintf(f, '%d %d %g %g %d\n', ev.runNumber, ev.eventNumber, ev.vertex(1), ev.vertex(2), ntrk);
            for trk = ev.tracks
                fprintf(f, '%g %g %g %g %g\n', trk.cotTheta, trk.curvature, trk.d0, trk.phi0, trk.z0);
            end
        end

        fclose(f);
    end
end % methods
end % classdef