//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
// import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
// import"https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/presets/ERC721PresetMinterPauserAutoId.sol";
import "./CryptoCaresNFT.sol";
contract Cryptocares is Crypto_Care_NFT{
    
    struct Services{
        
        uint256 service_id;
        address service_provider;
        address payable NGOaddress;
        uint256 minimum_donation_amount;
        uint256 duration;
        uint256 amountOfServices;
        bool service_disable;
        string description;
        
    }
    
    struct Service_Provider{
        
        address service_provider;
        string uri;
        
        
    }
    
    
    mapping(uint256 => Services) public Services_list;
    mapping(address => Service_Provider) public Service_Providers;
    address public NGO = 0x68A99f89E475a078645f4BAC491360aFe255Dff1; //address of COVID CryptoRelief India Fund
    uint256 private _serviceID = 0;
    uint256 private _tokenID = 0;
    
    event ServiceAdded(uint service_id, address service_provider);
    event ServiceDisabled(uint service_id);
    event ServiceEnabled(uint service_id);
    event ServiceProviderAdded(address service_provider,string uri);
    
    
    constructor() Crypto_Care_NFT("CryptoCares", "CC"){
        
        
        Services_list[0] = Services(0, 
                                address(0), 
                                payable(address(0x68A99f89E475a078645f4BAC491360aFe255Dff1)), 
                                0, 
                                5000 weeks, 
                                99999999, 
                                false, 
                                "None");
                                
        Service_Providers[address(0)] = Service_Provider(address(0), "None");
         
    }
    
    function _incrementserviceID() private returns(uint256){
        _serviceID += 1;
        return _serviceID;
    }
    
    function getServiceID() public view returns(uint256){
        return _serviceID;
    }
    
    function _addServiceProvider(
                                address service_provider,
                                string memory uri
                                 ) private {
                                     Service_Providers[service_provider]=Service_Provider(service_provider,uri);
                                     emit ServiceProviderAdded(service_provider,uri);
                                 }
    
    function Add_Services(
                        uint256 _minimum_donation_amount,
                        uint256 _duration,
                        uint256 _amountOfServices,
                        string memory _description,
                        string memory _contactURI) public {
                            
                    require(msg.sender != address(0), "Service Provider cannot be address(0)");
                    require(_minimum_donation_amount>0, "donation is not entered");
                    require(_duration > 0, "Duration of Service must be greater than 0 days");
                    require(_amountOfServices > 0, "Amount of Services provided not entered");
                    
                    uint256 _service_id = _incrementserviceID();
                    require(_service_id != 0, "Service ID 0 is for default 'None' ");
                    
                    Services storage service = Services_list[_service_id];
                    require(service.service_provider == address(0), "There is already a Service in this Service ID");
                    
                    address payable _NGOaddress = payable(address(0x68A99f89E475a078645f4BAC491360aFe255Dff1)); //address of COVID CryptoRelief India Fund
                    
                    Services_list[_service_id] = Services( _service_id,
                                                           msg.sender,
                                                           _NGOaddress,
                                                           _minimum_donation_amount,
                                                           (block.timestamp + _duration * 1 days),
                                                           _amountOfServices,
                                                           false,
                                                           _description);
                    
                    emit ServiceAdded(_service_id,msg.sender);
                    
                    _addServiceProvider(msg.sender, _contactURI);
                    
                    }
                    
    
                        
    function Avail_Service(uint256 id) payable public
    {
       Services storage service = Services_list[id];
       uint256 _amountOfServices = service.amountOfServices;
       require(service.duration - block.timestamp > 0, "Service has expired");
       require(service.service_disable != true, "Service is disabled"); // service should not be disabled
       require(_amountOfServices > 0, "All available services have been minted"); // amount of services should not be depleted
       require(msg.value >= service.minimum_donation_amount, "Donation Amount must be greater than or equal to minimum value"); // donation amount sent must be above minimum_donation_amount
       address payable _toNGO = service.NGOaddress;
       _toNGO.transfer(msg.value);
       service.amountOfServices = service.amountOfServices - 1;
       
       if(service.amountOfServices == 0 || service.duration - block.timestamp <= 0){
            _disableService(service.service_id);
       }
        //mint NFT
        mintNFT(msg.sender, _tokenID, "https://upload.wikimedia.org/wikipedia/commons/2/24/NFT_Icon.png");
        // _mint(msg.sender, _tokenID);
        // _setTokenURI(_tokenID, "https://upload.wikimedia.org/wikipedia/commons/2/24/NFT_Icon.png");
        // _tokenID += 1;
    }
    
    function Disable_Service(uint256 id) public {
        
        Services storage service = Services_list[id];
        
        require(msg.sender == service.service_provider,"You are not Service Provider");
        require(service.service_disable!=true,"Service is already disabled");
        
        _disableService(id);
        
        
    }
    
    function _disableService(uint256 id) private {
        Services storage service = Services_list[id];
        
        service.service_disable=true;
        emit ServiceDisabled(service.service_id);
    }
    
    function Enable_Service(uint256 id) public {
        
        Services storage service = Services_list[id];
        
        require(msg.sender == service.service_provider,"You are not Service Provider");
        require(service.service_disable!=false,"Service is already enabled");
        require(service.amountOfServices > 0, "All available services have been minted");
        
        service.service_disable=false;
        
        emit ServiceEnabled(service.service_id);
        
    }
    
    function Get_Service(uint256 id) public view returns(Services memory){
        return Services_list[id];
    }
    
    function Get_ServiceProvider(address service_provider) public view returns(Service_Provider memory){
        return Service_Providers[service_provider];
    }
    
    function mintNFT(
            address _to,
            uint256 _tokenId,
            string memory tokenURI_
        ) private{
            _mint(_to, _tokenId);
            _setTokenURI(_tokenId, tokenURI_);
            _tokenID += 1;
        }
        
    function getCurrentTokenID() view public returns(uint256) {
        return _tokenID;
    }
    
    // function getServicesFromProvider(address  _service_provider) public view returns(Services[] memory){
    //     Services[] memory servicesFromProvider;
    //     for(uint256 i = 0; i < Services_list.length; i++) {
    //         Services storage service = Services_list[i];
            
    //         if(service.service_provider == _service_provider){
    //             servicesFromProvider.push(service);
    //         }
                
    //     }
    //     return servicesFromProvider;
    // }
}


