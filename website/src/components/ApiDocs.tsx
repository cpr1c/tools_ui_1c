import SwaggerUI from "swagger-ui-react";
import "swagger-ui-react/swagger-ui.css";

export default function ApiDocs() {
  const spec = "/openapi/published-http-services.json";
  return (
    <SwaggerUI
      url={spec}
      docExpansion="list"
      defaultModelsExpandDepth={1}
      persistAuthorization={true}
      supportedSubmitMethods={[]}
    />
  );
}
