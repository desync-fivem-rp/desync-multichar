import React, { useState } from "react";
import "./App.css";
import { debugData } from "../utils/debugData";
import CharacterSelect from './CharacterSelect';

// This will set the NUI to visible if we are
// developing in browser
debugData([
    {
      action: "setVisible",
      data: true,
    },
]);

const App: React.FC = () => {

    return (
      <div className="nui-wrapper">
        <CharacterSelect />
      </div>
    );
  };

export default App;
