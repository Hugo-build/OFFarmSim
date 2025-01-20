function Name = appendTime2Name()

    date = char( datetime("today") );
    dateANDtime = char(datetime("now"));
    time = dateANDtime(end-7:end);
    hour = time(1:2);minute = time(4:5);second = time(7:8);
    
    Name = [date '_' hour '-' minute '-' second];

end

