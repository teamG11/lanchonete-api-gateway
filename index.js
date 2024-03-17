exports.handler = async (event) => {  
    const response = {
      statusCode: 200,
      headers: {
        "Content-Type": "application/json"
      },
      body: JSON.stringify({
      message: "Lambda response 200!"
    })
  };
  return response;
  };