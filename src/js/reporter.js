window.addEventListener("DOMContentLoaded", () => {
  const addMissingForm = document.getElementById("addMissingForm");
  const bookForm = document.getElementById("bookForm");
  const scheduleForm = document.getElementById("scheduleForm");

  addMissingForm.addEventListener("submit", async (e) => {
    e.preventDefault();
    const name = document.getElementById("mpName").value;
    const age = parseInt(document.getElementById("mpAge").value);
    const height = parseInt(document.getElementById("mpHeight").value);
    const desc = document.getElementById("mpDesc").value;
    const division = document.getElementById("mpDivision").value;
    const contact = document.getElementById("mpContact").value;

    try {
      await contract.methods
        .addMissingPerson(name, age, height, desc, division, contact)
        .send({ from: (await web3.eth.getAccounts())[0] });
      alert("Missing person reported successfully");
    } catch (err) {
      console.error(err);
      alert("Failed to report");
    }
  });

  bookForm.addEventListener("submit", async (e) => {
    e.preventDefault();
    const caseId = document.getElementById("bookCaseId").value;
    const investigator = document.getElementById("bookInvestigator").value;
    const admin = document.getElementById("bookAdmin").value;
    const slot = document.getElementById("bookSlot").value;
    const value = web3.utils.toWei("0.01", "ether");

    try {
      await contract.methods
        .bookAppointment(caseId, investigator, admin, slot)
        .send({ from: (await web3.eth.getAccounts())[0], value });
      alert("Appointment booked successfully");
    } catch (err) {
      console.error(err);
      alert("Booking failed");
    }
  });

  scheduleForm.addEventListener("submit", async (e) => {
    e.preventDefault();
    const address = document.getElementById("scheduleAddress").value;

    try {
      const schedule = await contract.methods.getInvestigatorSchedule(address).call();
      const resultDiv = document.getElementById("scheduleResult");
      resultDiv.innerHTML = schedule.length === 0
        ? "No appointments"
        : schedule.map(a => `Case ${a.caseId}, Slot: ${a.slot}`).join("<br>");
    } catch (err) {
      console.error(err);
      alert("Failed to load schedule");
    }
  });
});
