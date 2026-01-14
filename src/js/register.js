const roleMap = {
    admin: 0,
    reporter: 1,
    investigator: 2
  };
  
  window.addEventListener("DOMContentLoaded", () => {
    const registerForm = document.getElementById("registerForm");
    const loginForm = document.getElementById("loginForm");
  
    registerForm.addEventListener("submit", async (e) => {
      e.preventDefault();
      const role = roleMap[document.getElementById("role").value];
      const name = document.getElementById("name").value;
      const nid = parseInt(document.getElementById("nid").value);
      const userAddressInput = document.getElementById("userAddress").value;
  
      const accounts = await web3.eth.getAccounts();
      const caller = accounts[0];
  
      try {
        await contract.methods
          .registerUser(nid, name, role, userAddressInput)
          .send({ from: caller });
        alert("Registered successfully!");
      } catch (err) {
        console.error(err);
        alert("Registration failed");
      }
    });
  
    loginForm.addEventListener("submit", async (e) => {
      e.preventDefault();
      const loginRole = roleMap[document.getElementById("loginRole").value];
      const accounts = await web3.eth.getAccounts();
      const user = await contract.methods.registeredUsers(accounts[0]).call();
  
      if (!user.registered) {
        alert("User not registered");
        return;
      }
  
      if (parseInt(user.role) !== loginRole) {
        alert("Incorrect role selected");
        return;
      }
  
      // Redirect to role-specific page
      if (loginRole === 0) window.location.href = "admin.html";
      else if (loginRole === 1) window.location.href = "reporter.html";
      else if (loginRole === 2) window.location.href = "investigator.html";
    });
  });
