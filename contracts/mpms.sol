pragma solidity >=0.7.0 <0.9.0;

contract MPMS {
    enum Roles { Admin, Reporter, Investigator }
    enum Status { Missing, Found }

    address public contractOwner;

    constructor() {
        contractOwner = msg.sender;
    }

    struct UserData {
        uint NID;
        string username;
        Roles role;
        string userAddress;
        bool registered;
    }

    mapping(address => UserData) public registeredUsers;
    address[] public userAddresses;

    // Modifier to check if caller is registered
    modifier onlyRegistered() {
        require(registeredUsers[msg.sender].registered, "User not registered");
        _;
    }

    // Modifier for specific role access
    modifier onlyRole(Roles _role) {
        require(registeredUsers[msg.sender].role == _role, "Unauthorized role");
        _;
    }

    function registerUser(
        uint _nid, 
        string memory _name, 
        Roles _role, 
        string memory _address
    ) public {
        require(!registeredUsers[msg.sender].registered, "Already registered!");
        require(_nid > 0, "Invalid NID");
        require(bytes(_name).length > 0, "Name cannot be empty");
        require(bytes(_address).length > 0, "Address cannot be empty");

        registeredUsers[msg.sender] = UserData(_nid, _name, _role, _address, true);
        userAddresses.push(msg.sender);

        if (_role == Roles.Admin) {
            isAdmin[msg.sender] = true;
            admins.push(msg.sender);
        }
    }

    struct MissingPerson {
        string name;
        uint age;
        uint height;
        Status status;
        string description;
        string division;
        string contactNumber;
        string urgencyLevel;
        address[] investigators;
        bool exists;
    }

    mapping(uint => MissingPerson) public missingCases;
    uint private caseCounter;
    uint[] public allCaseIds;

    string[] public divisions = [
        "Dhaka", "Chattogram", "Khulna", "Rajshahi", 
        "Barisal", "Sylhet", "Rangpur", "Mymensingh"
    ];

    function addMissingPerson(
        string calldata _name, 
        uint _age, 
        uint _height,
        string calldata _desc, 
        string calldata _division, 
        string calldata _contact
    ) public onlyRegistered onlyRole(Roles.Reporter) {
        require(_age > 0, "Age must be positive");
        require(_height > 0, "Height must be positive");
        require(bytes(_name).length > 0, "Name cannot be empty");
        require(bytes(_desc).length > 0, "Description cannot be empty");
        require(bytes(_contact).length > 0, "Contact number cannot be empty");
        require(isValidDivision(_division), "Invalid division");

        caseCounter++;
        
        string memory urgency = (_age < 18) ? "High" : (_age > 50) ? "Medium" : "Low";

        missingCases[caseCounter] = MissingPerson({
            name: _name,
            age: _age,
            height: _height,
            status: Status.Missing,
            description: _desc,
            division: _division,
            contactNumber: _contact,
            urgencyLevel: urgency,
            investigators: new address[](0),
            exists: true
        });

        allCaseIds.push(caseCounter);
    }

    function updateStatus(
        uint _caseId, 
        Status _newStatus
    ) public onlyRegistered onlyRole(Roles.Admin) {
        require(missingCases[_caseId].exists, "Case does not exist");
        require(missingCases[_caseId].status != Status.Found, "Already found, cannot revert");
        require(_newStatus != missingCases[_caseId].status, "Status unchanged");

        missingCases[_caseId].status = _newStatus;
    }

    function assignInvestigator(
        uint _caseId, 
        address _investigator
    ) public onlyRegistered onlyRole(Roles.Admin) {
        require(missingCases[_caseId].exists, "Case does not exist");
        require(registeredUsers[_investigator].role == Roles.Investigator, "Not an investigator");
        require(!isInvestigatorAssigned(_caseId, _investigator), "Already assigned");

        missingCases[_caseId].investigators.push(_investigator);
    }

    function isInvestigatorAssigned(
        uint _caseId, 
        address _investigator
    ) public view returns (bool) {
        for (uint i = 0; i < missingCases[_caseId].investigators.length; i++) {
            if (missingCases[_caseId].investigators[i] == _investigator) {
                return true;
            }
        }
        return false;
    }

    function isValidDivision(string memory division) private view returns (bool) {
        for (uint i = 0; i < divisions.length; i++) {
            if (keccak256(bytes(divisions[i])) == keccak256(bytes(division))) {
                return true;
            }
        }
        return false;
    }

    function getMissingCountByDivision(string memory division) public view returns (uint) {
        require(isValidDivision(division), "Invalid division");
        
        uint count = 0;
        for (uint i = 0; i < allCaseIds.length; i++) {
            if (keccak256(bytes(missingCases[allCaseIds[i]].division)) == keccak256(bytes(division))) {
                if (missingCases[allCaseIds[i]].status == Status.Missing) {
                    count++;
                }
            }
        }
        return count;
    }

    function getAllMissingCounts(bool sortDescending) public view returns (string[] memory, uint[] memory) {
        uint[] memory counts = new uint[](divisions.length);
        string[] memory sortedDivisions = new string[](divisions.length);
        
        // Create a copy of divisions array
        for (uint i = 0; i < divisions.length; i++) {
            sortedDivisions[i] = divisions[i];
            counts[i] = getMissingCountByDivision(divisions[i]);
        }

        // Bubble sort
        for (uint i = 0; i < sortedDivisions.length; i++) {
            for (uint j = i + 1; j < sortedDivisions.length; j++) {
                bool shouldSwap = sortDescending 
                    ? counts[i] < counts[j] 
                    : counts[i] > counts[j];
                
                if (shouldSwap) {
                    // Swap counts
                    (counts[i], counts[j]) = (counts[j], counts[i]);
                    // Swap divisions
                    (sortedDivisions[i], sortedDivisions[j]) = (sortedDivisions[j], sortedDivisions[i]);
                }
            }
        }

        return (sortedDivisions, counts);
    }

    struct Appointment {
        uint caseId;
        address reporter;
        string slot;
        uint256 startMinutes; // Added: Store time as minutes since midnight
        uint256 endMinutes;   // Added: For overlap detection
        address paidAdmin; // Track which admin received payment
    }

    struct FoundAlert {
        uint caseId;
        address investigator;
        string note;
        bool reviewed;
    }

    mapping(uint => FoundAlert) public foundAlerts;


    address[] public admins;
    mapping(address => bool) public isAdmin;
    mapping(address => Appointment[]) public investigatorAppointments;
    mapping(string => bool) public slotBooked;

    function bookAppointment(
        uint _caseId,
        address _investigator,
        address _selectedAdmin, // Reporter chooses admin
        string memory _slot
    ) public payable onlyRegistered onlyRole(Roles.Reporter) {
        require(isAdmin[_selectedAdmin], "Invalid admin");
        require(msg.value >= 0.01 ether, "Minimum 0.01 ether required");
        require(missingCases[_caseId].exists, "Invalid case");
        require(missingCases[_caseId].status == Status.Missing, "Person already found");
        require(!slotBooked[_slot], "Slot string already used");
        require(registeredUsers[_investigator].role == Roles.Investigator, "Not an investigator");
        require(validateSlotFormat(_slot), "Invalid slot format");

        // Convert slot to minutes for overlap check
        (uint256 startMins, uint256 endMins) = parseSlotToMinutes(_slot);
        
        // Check for overlapping time slots (NEW)
        Appointment[] storage appointments = investigatorAppointments[_investigator];
        for (uint i = 0; i < appointments.length; i++) {
            bool overlaps = (startMins < appointments[i].endMinutes) && 
                        (endMins > appointments[i].startMinutes);
            require(!overlaps, "Time slot overlaps with existing appointment");
        }

        // Store appointment with minute values (NEW)
        investigatorAppointments[_investigator].push(Appointment({
            caseId: _caseId,
            reporter: msg.sender,
            paidAdmin: _selectedAdmin,
            slot: _slot,
            startMinutes: startMins,
            endMinutes: endMins
        }));

        slotBooked[_slot] = true;

        payable(_selectedAdmin).transfer(msg.value);

        emit AppointmentBooked(_caseId, msg.sender, _investigator, _selectedAdmin, _slot);
    
    }

    event AppointmentBooked(
    uint indexed caseId,
    address reporter,
    address investigator,
    address admin,
    string slot

    );

    event FoundReported(uint indexed caseId, address investigator, string note);

    // New helper function
    function parseSlotToMinutes(string memory _slot) private pure returns (uint256 start, uint256 end) {
        bytes memory b = bytes(_slot);
        require(b.length == 11, "Invalid slot length");
        require(b[2] == ':' && b[5] == '-' && b[8] == ':', "Invalid slot format");

        uint startH = (uint8(b[0]) - 48) * 10 + (uint8(b[1]) - 48);
        uint startM = (uint8(b[3]) - 48) * 10 + (uint8(b[4]) - 48);
        uint endH = (uint8(b[6]) - 48) * 10 + (uint8(b[7]) - 48);
        uint endM = (uint8(b[9]) - 48) * 10 + (uint8(b[10]) - 48);

        require(startH < 24 && startM < 60 && endH < 24 && endM < 60, "Time value out of range");

        start = startH * 60 + startM;
        end = endH * 60 + endM;
    }

    // Modified validation to ensure proper slot sequencing
    function validateSlotFormat(string memory _slot) private pure returns (bool) {
        bytes memory b = bytes(_slot);
        if (b.length != 11) return false;
        if (b[2] != ':' || b[5] != '-' || b[8] != ':') return false;

        uint startH = (uint8(b[0]) - 48) * 10 + (uint8(b[1]) - 48);
        uint startM = (uint8(b[3]) - 48) * 10 + (uint8(b[4]) - 48);
        uint endH = (uint8(b[6]) - 48) * 10 + (uint8(b[7]) - 48);
        uint endM = (uint8(b[9]) - 48) * 10 + (uint8(b[10]) - 48);

        // Validate time ranges
        if (startH > 23 || endH > 23) return false;
        if (startM > 59 || endM > 59) return false;

        // Ensure proper 10-minute increment sequencing (NEW)
        if (startM % 10 != 0 || endM % 10 != 0) return false;
        if (endM != (startM + 10) % 60) return false;
        if (endH != startH + (startM + 10 >= 60 ? 1 : 0)) return false;

        return true;
    }

    function getInvestigatorSchedule(address _investigator) public view returns (Appointment[] memory) {
        return investigatorAppointments[_investigator];
    }

    function reportFoundPerson(uint _caseId, string memory _note) public onlyRegistered onlyRole(Roles.Investigator) {
        require(missingCases[_caseId].exists, "Case does not exist");
        require(missingCases[_caseId].status == Status.Missing, "Already marked found");
        require(!foundAlerts[_caseId].reviewed, "Already reported and reviewed");

        foundAlerts[_caseId] = FoundAlert({
            caseId: _caseId,
            investigator: msg.sender,
            note: _note,
            reviewed: false
        });

        emit FoundReported(_caseId, msg.sender, _note);
    }



}

