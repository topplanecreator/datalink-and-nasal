# Coordinate Setup
var coordsetup = func(lat, lon, alt) {
    var coord = geo.Coord.new();
    var gndelev = alt * FT2M;  # Convert altitude from feet to meters
  
    # Print out input coordinates
    print("coord: lat:" ~ lat);
    print("coord: lon:" ~ lon);
    print("coord: alt:" ~ alt);

    # If the ground elevation is not set or invalid, try fetching it
    if (gndelev <= 0) {
        gndelev = geo.elevation(lat, lon);  # Attempt to get ground elevation

        # Handle missing or invalid elevation
        if (gndelev == nil) {
            print("Warning: Ground elevation not found, defaulting to 0.");
            gndelev = 0;  # Fallback to a default value (0 meters)
        } else {
            print("gndelev: " ~ gndelev);  # Print out the ground elevation
        }
    }

    # Set the coordinate with latitude, longitude, and calculated elevation
    coord.set_latlon(lat, lon, gndelev);
    return coord;
}

# Sender Function
var send = func(coord=nil) {
    if (coord != nil) {
        # Send provided coordinate
        datalink.send_data({"point": coord});
    } else {
        # If no coordinate is provided, fetch the current position
        var lat = getprop("position/latitude-deg");
        var lon = getprop("position/longitude-deg");
        var alt = getprop("position/altitude-ft");
        
        # Create a new coordinate object with current position data
        var data = geo.Coord.new;
        data.set_latlon(lat, lon, alt * FT2M);  # Convert altitude to meters
        datalink.send_data({"point": data});
    }
}   

# Data Link Loop to Process Incoming Data
var is_sending = nil;
var data = nil;
var dlink_loop = func {
    # Check if there's active data to process
    if (getprop("instrumentation/datalink/data") != 0) {
        return;
    }

    # Get incoming data from the datalink
    data = datalink.get_data(callsign);
    if (data != nil and data.on_link()) {
        var coord = data.point();
        if (coord != nil) {
            # Process the received data (coordinates and altitude)
            var reclat = data.lat();
            var reclon = data.lon();
            var recalt = data.alt() * M2FT;  # Convert altitude to feet

            # Data received, now you can implement further actions with the coordinates
            # e.g., updating UI, performing calculations, or tracking
        }
    }
}

# Situational Awareness System (Tracking Other Callsigns)
var readcallsign = func(callsign) {
    # Skip if no active datalink data
    if (getprop("instrumentation/datalink/data") != 0) {
        return;
    }

    # Fetch data for the specified callsign
    data = datalink.get_data(callsign);
    if (data != nil and data.on_link()) {
        var coord = data.point();
        if (coord != nil) {
            # Process data received from the callsign
            var reclat = data.lat();
            var reclon = data.lon();
            var recalt = data.alt() * M2FT;  # Convert altitude to feet

            # Data received from the callsign, now you can implement further actions
            # Example: updating internal systems or reacting based on position
            # setprop("datalink/friendlyposlat", reclat);
        }
    }
}

# Start the data link loop every 3.5 seconds
var timer = maketimer(3.5, dlink_loop);
timer.start();
